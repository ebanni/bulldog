require 'spec_helper'


describe Bill do
  before do
    @attr = {
      account_id: 1,
      date: '20140101',
      customer_id: 1,
      supplier_id: 1,
      category_id: 1,
      description: "",
      amount: "1"
    }
  end

  it "is valid with valid attributes" do
    expect(Bill.new(@attr)).to be_valid
  end

  it "is invalid without date" do
    expect(Bill.new(@attr.merge(date: ""))).to_not be_valid
  end

  it "is invalid without customer_id" do
    expect(Bill.new(@attr.merge(customer_id: ""))).to_not be_valid
  end

  it "is invalid without supplier_id" do
    expect(Bill.new(@attr.merge(supplier_id: ""))).to_not be_valid
  end

  it "is invalid without account_id" do
    expect(Bill.new(@attr.merge(account_id: ""))).to_not be_valid
  end

  it "is invalid without category_id" do
    expect(Bill.new(@attr.merge(category_id: ""))).to_not be_valid
  end

  it "is invalid without amount" do
    expect(Bill.new(@attr.merge(amount: ""))).to_not be_valid
  end

  it "can name its customer, supplier etc." do
    customer = create(:customer, name: 'John')
    supplier = create(:supplier, name: 'Fred')
    category = create(:category, name: 'Food')
    bill = Bill.new(@attr.merge(customer_id: customer.id,
                                supplier_id: supplier.id,
                                category_id: category.id))
    expect(bill.customer_name).to eq 'John'
    expect(bill.supplier_name).to eq 'Fred'
    expect(bill.category_name).to eq 'Food'
  end
end
