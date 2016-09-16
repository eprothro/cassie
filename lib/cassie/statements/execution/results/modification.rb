module Cassie::Statements::Results
  module Modification

    def success?
      # when using conditional update, the server will respond
      # with a result-set containing a special result named "[applied]".
      return false if rows.first && rows.first["[applied]"] == false

      super
    end
  end
end