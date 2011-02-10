module Mascot
  class DAT::Parameters
    include Enumerable

    # An array of parameter names
    attr_reader :names

    # A hash to access the parameters by the parameter name
    #
    # @param name A String of the parameter name
    # @return String The String value of the parameter
    #
    attr_reader :parameters

    def initialize params_str
      @parameters = {}
      @names = []

      params_str.split("\n").each do |l|
        k,v = l.split("=")
        next unless k && v
        @parameters[k] = v
        @names << k
      end
    end

    def []k
      @parameters[k]
    end

    def method_missing(m,args)
      if @parameters.has_key?(m.to_s)
        @parameters[m.to_s]
      else
        super
      end
    end
  end
end
