module Mascot
  class DAT::Parameters

    # An array of parameter names
    attr_reader :names

    # A hash to access the parameters by the parameter name
    #
    # @param name A String of the parameter name
    # @return String The String value of the parameter
    #
    attr_reader :params


    def initialize masses_section
      @params = {}
      @names = []

      masses_section.split("\n").each do |l|
        k,v = l.split("=")
        next unless k && v
        @params[k] = v
        @names << k
      end
    end
  end
end
