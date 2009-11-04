begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'csv_importer'
include CSVImporter

# Define a Product Struct for test purposes
class Product < Struct.new(:title, :price, :brand, :image); end

def new_importer
  Importer.new(File.open(File.dirname(__FILE__)+ "/csv/sample.csv", "rb"), Product)
end