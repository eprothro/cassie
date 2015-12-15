class Resource
  attr_accessor :id

  def initiailize
    @id = rand(1000000000)
  end
end