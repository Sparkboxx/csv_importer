module CSVImporter
  VERSION = "0.0.3"
  require 'csv'


  class Importer
    attr_reader :reader, :delimiter, :csv_columns, :columns, :klass, :dictionary, :objects, :save
        
    def initialize(str_or_readable, klass=nil, dictionary={})
      @klass = klass
      @save = save
      @dictionary = {}
      dictionary.each_pair{|k,v| @dictionary[k.downcase] = v.downcase}
      @delimiter, @csv_columns = determine_delimiter_and_columns(str_or_readable)
      @columns = match_columns
      @reader = CSV::Reader.create(str_or_readable, @delimiter)
    end
    
    def objects(save=false)
      return @objects if !@objects.nil?
      @objects = Array.new if @object.nil?
      
      first = true
      @reader.each do |row|
        #TODO: Ruby 1.9 has header option would be nicer instead of this hack.
        if !first
          object = @klass.new
          active_record = object.respond_to?(:update_attributes)
          attribute_hash = {} if active_record
          @columns.each_pair do |column, row_number|
            value = row[row_number]
            value = value.strip if !value.nil?
            object.send("#{column}=", value) if !active_record
            attribute_hash[column] = value if active_record
          end
          object.attributes = attribute_hash if active_record
          object.save if save
          @objects << object
        else
          first = false
        end
      end
      return @objects
    end
    
    private
    def determine_delimiter_and_columns(str_or_readable)
      case str_or_readable
      when IO
        first_line = str_or_readable.gets
        str_or_readable.pos = 0 #Reset IO cursor position, else the first line will be skipped
      when String
        #TODO: Find efficient way to get the first line by stoping at first newline character
        #TODO: Test for different newline characters on windows machines
        first_line = str_or_readable.split("\n")[0]
      else
        #TODO: What's the best exception to raise?
        raise ArgumentException, "No String or IO argument detected"
      end

      #TODO: Fix repitition in determine_delimiter_and_columns
      comma = first_line.split(",")
      semicolon = first_line.split(";")
      if comma.count > semicolon.count
        return ",",comma.map!{|c| c.strip.downcase}
      else
        return ";",semicolon.map!{|c| c.strip.downcase}
      end
    end
    
    def match_columns
      columns = {} if @columns.nil?
      klass = @klass.new
      @csv_columns.each_with_index do |column, index|
        if klass.respond_to?("#{column}=")
          columns[column] = index
        elsif klass.respond_to?("#{@dictionary[column.downcase]}=")
          columns[@dictionary[column.downcase]] = index
        end
      end
      return columns
    end
    
    
  end
end