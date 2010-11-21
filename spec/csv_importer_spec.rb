require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Initialze CSV" do
  include CSVImporter

  it "should open a reader on the given CSV file" do
    importer = new_importer
    importer.reader.class == CSV::Reader
  end
  
  it "should open a reader given a string" do
    importer = Importer.new("foo,bar,foo,bar", Product)
    importer.reader.class == CSV::Reader
  end
  
  it "should detect the ; file delimiter" do
    importer = new_importer
    importer.delimiter.should == ";"
  end
  
  it "should detect the , file delimiter" do
    importer = Importer.new("foo,bar,foo,bar,foo", Product)
    importer.delimiter.should == ","
  end
  
  it "should pick the delimiter with the maximum split count" do
    importer = Importer.new("column,col;umn,column,col;umn,column,column", Product)
    importer.delimiter.should == ","
  end

  it "should set the columns of the CSV file" do
    importer = Importer.new("a,b,c,d,e\nfoo,bar,foo,bar,foo", Product)
    importer.csv_columns.should == ["a","b","c","d","e"]
  end
  
  it "should strip the column names" do
    importer = Importer.new("a, b, c , d ", Product)
    importer.csv_columns.should == ["a","b","c","d"]
  end
  
  it "should memorize the class to handle the rows" do
    importer = Importer.new("a,b", Product)
    importer.klass.should == Product
  end
  
  it "should match the CSV columns with the Object columns" do
    importer = Importer.new("title, price, brand, foo, barred", Product)
    importer.columns.should == {"title"=>0, "price"=>1, "brand"=>2}
  end

  it "should match the CSV columns with the Object columns through the dictionary" do
    dictionary = {"the title"=>"title", "the price"=>"price", "the brand" => "brand"}
    importer = Importer.new("the title, the price, the brand", Product, dictionary)
    importer.columns.should == {"title"=>0, "price"=>1, "brand"=>2}
  end
  
  it "should ignore case differences in the dictionary" do
    dictionary = {"THE title"=>"title", "the PRice"=>"price", "The Brand" => "brand"}
    importer = Importer.new("the title, the price, the brand", Product, dictionary)
    importer.columns.should == {"title"=>0, "price"=>1, "brand"=>2}
  end
  
  it "should be able to cope with partial dictionaries" do
    dictionary = {"Description"=>"title", "Saleprice"=>"Price"}
    importer = Importer.new(File.open(File.dirname(__FILE__)+ "/csv/sample.csv", "rb"), Product, dictionary)
    importer.columns.should == {"title"=>0, "price"=>3, "brand"=>1, "image"=>4}
  end
  
  it "should create the collection of objects" do
    dictionary = {"Description"=>"title", "Saleprice"=>"Price"}
    importer = Importer.new(File.open(File.dirname(__FILE__)+ "/csv/sample.csv", "rb"), Product, dictionary)
    importer.objects.count.should == 13 #See spec/csv/sample.csv
  end
  
  it "shoud not turn the title line into an object" do
    importer = Importer.new("title,brand\nThis is a nice title!, belonging to a brand", Product)
    importer.objects[0].title.should == "This is a nice title!"
    importer.objects[0].brand.should == "belonging to a brand"
    importer.objects.count.should == 1    
  end   
    
  
end
