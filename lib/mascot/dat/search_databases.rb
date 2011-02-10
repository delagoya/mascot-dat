module Mascot
  class DAT
    class SearchDatabases
      include Enumerable

      def initialize(params=nil)
        @dbs = []
        if params
          parse(params)
        end
      end

      def self.parse(params)
        tmp = SearchDatabases.new(params)
      end

      def []idx
        @dbs[idx]
      end

      def parse(params)
        dbkeys = params.names.grep(/db/i).sort
        dbkeys.each do |k|
          @dbs <<  params[k]
        end
      end

      def each
        @dbs.each do |db|
          yield db
        end
      end
    end
  end
end
