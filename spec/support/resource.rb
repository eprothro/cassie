class Resource
  attr_accessor :id

  def initialize(opts={})
    opts.each do |k,v|
      if respond_to?("#{k}=")
        send("#{k}=", v)
      end
    end
  end
end