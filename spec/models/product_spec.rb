require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it 'requires a name, slug, and price' do
      product = described_class.new

      expect(product).not_to be_valid
      expect(product.errors.attribute_names).to contain_exactly(:name, :slug, :price)
    end

    it 'requires a unique slug' do
      described_class.create!(name: 'Desk lamp', slug: 'desk-lamp', price: 25)
      duplicate = described_class.new(name: 'Reading lamp', slug: 'desk-lamp', price: 30)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include('has already been taken')
    end
  end

  describe 'status' do
    it 'defaults to in_stock' do
      expect(described_class.new.status).to eq('in_stock')
    end

    it 'defines the out_of_stock and in_stock statuses' do
      expect(described_class.statuses).to eq('out_of_stock' => 0, 'in_stock' => 1)
    end
  end
end
