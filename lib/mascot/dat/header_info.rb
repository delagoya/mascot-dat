module Mascot
  class DAT
    class HeaderInfo
      #--
      # Example DAT header
      # --gc0p4Jq0M2Yt08jU534c0p
      # Content-Type: application/x-Mascot; name="header"
      #
      # sequences=89598
      # sequences_after_tax=89598
      # residues=35885089
      # distribution=71889,1061,1406,1461,1505,1372,1176,1031,928,778,787,665,560,637,478,474,394,356,229,248,228,203,190,173,155,148,134,117,110,73,61,47,58,62,47,28,37,26,26,18,19,19,11,10,10,13,14,11,5,5,5,4,8,10,7,6,2,5,7,2,2,6,1,2,2,1,3,2,4,1,0,2,0,0,3,0,0,0,0,0,0,0,2,0,1,0,0,0,0,0,0,0,3,1,0,1,2,0,1,0,0,0,0,0,1,3,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,2
      # distribution_decoy=80925,962,1252,1124,1025,903,677,518,400,336,267,235,195,160,125,102,66,53,53,37,32,32,19,19,13,20,6,8,6,9,2,4,5,1,2,0,0,2,0,0,0,1,0,0,0,2
      # exec_time=824
      # date=1291991220
      # time=14:27:00
      # queries=8257
      # max_hits=50
      # version=2.3.01
      # fastafile=/mnt/mascot/sequence/cRAP/current/cRAP_20100324.fasta
      # release=cRAP_20100324.fasta
      # sequences1=112
      # sequences_after_tax1=112
      # residues1=37421
      # fastafile2=/mnt/mascot/sequence/IPI_human/current/IPI_human_3.75.fasta
      # release2=IPI_human_3.75.fasta
      # sequences2=89486
      # sequences_after_tax2=89486
      # residues2=35847668

      # attr_accessor :queries, :time, :date, :exec_time,
      #               :max_hits, :version,
      #               :databases, :total_seqs, :total_seqs_after_tax,
      #               :total_residues
      #++

      attr_reader :distribution

      def initialize(header_section)
        @keys = []
        @values = {}
        @databases = []
        kv_rgx = /^(\w+)=(.+)$/
        header_section.split("\n").grep(/^(\w+)=(.+)$/) do |line|
          key,val = $1,$2
          case key
          when /^distribution/
            # set distibution information
            @values[key.to_sym] = val.split(",").collect{|e| e.to_i }
          else
            @keys << key
            @values[key.to_sym] = val
            define_method key.to_sym do
              @values[key.to_sym]
            end
          end
        end
      end

      def search_databases
        unless @databases
          @databases = {:db=>{}}
          @keys.grep(/^fastafile(\d*)/) do |k|
            idx = $1.to_i + 1
            @databases[:db][@values["release#{$1}".to_sym]] =
            {:path => @values["fastafile#{$1}".to_sym],
            :sequences => @values["sequences#{idx}".to_sym],
            :sequences_after_tax => @values["sequences_after_tax#{idx}".to_sym],
            :residues => @values["residues#{idx}".to_sym]}
          end
        end
        @databases
      end

    end
  end
end