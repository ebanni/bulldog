require 'rails_helper'
require 'stripe_mock'

describe InvoiceMailer, type: :request do

  after { StripeMock.stop }

  before do
    Stripe.api_key = 'sk_fake_api_key' # to ensure that Stripe.com isn't processing this
    StripeMock.start
    # StripeMock.toggle_debug(true)
    allow_any_instance_of(Account).to receive(:get_customer).and_return(true)
    allow_any_instance_of(Account).to receive(:process_sale).and_return(true)
    @account = FactoryGirl.create(:account, stripe_customer_token: "cust_token")
    @charge = Stripe::Charge.create( :amount => 400, 
      :currency => "gbp",
       :card => "empty",
       :description => "Charge for test@example.com" )
    @event = StripeMock.mock_webhook_event('invoice.payment_succeeded', {
        :customer => "cust_token",
        :total => 1200,
        :charge => @charge.id,
        :starting_balance => -2400,
        :ending_balance => -1200,
        :amount_due => 0
      })
    @invoice = @event.data.object
    @error = {message: 'test error message'}
    
  end

  describe '#after_invoice_payment_succeeded!' do
    it "responds with success" do
      post 'stripe/events', @event.to_h, {'HTTP_ACCEPT' => "application/json"}
      expect(response.code).to eq '201'
    end

    it "mocks a stripe webhook" do
      expect(@event.id).to_not be_nil
      expect(@invoice.id).to_not be_nil
      expect(@invoice.id).to eq "in_00000000000000"
      expect(@invoice.lines.count).to eq 3
    end

    it "sends an error email if there is an error" do

      @event = StripeMock.mock_webhook_event('invoice.payment_succeeded', {
        :customer => "missing",
        :total => 1200,
        :charge => ""
      })

      post 'stripe/events', @event.to_h, {'HTTP_ACCEPT' => "application/json"}
      open_email('info@bulldogclip.co.uk', with_text: 'Invoice Webhook Error')      
    end

  end

  describe '#error_invoice' do
    before do
      @mail =  InvoiceMailer.error_invoice(@invoice, @event)
    end

    it "renders the error message" do
      expect(@mail.body).to include('BulldogClip Subscription Invoice Webhook Error')
    end

    it "sends an email" do
      expect { @mail.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "renders the to" do
      expect(@mail.to).to eq ['info@bulldogclip.co.uk']
    end
  end

  describe '#new_invoice' do
    before do
      @mail =  InvoiceMailer.new_invoice(@account, @invoice, @charge)
    end

    it "renders the subject" do
      expect(@mail.subject).to eq 'BulldogClip - Your new invoice'
    end

    it "renders the to" do
      expect(@mail.to).to eq [@account.email]
    end

    it "renders the from" do
      expect(@mail.from).to eq ['noreply@bulldogclip.co.uk']
    end

    it "sends an email" do
      expect { @mail.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "#update_account" do
    it "stores a date" do
      invoice_dbl = double("stripe invoice")
      allow(Stripe::Invoice).to receive_message_chain(:upcoming, :date).and_return(1405670902)
      InvoiceMailer.update_account(@account, @invoice)
      expect(@account.next_invoice).to eq "2014-07-18".to_date
    end
  end
end
