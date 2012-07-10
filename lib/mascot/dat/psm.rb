module Mascot
  class DAT
    # A single Peptide Spectrum Match (PSM) result. In Mascot parlance, this is a
    # match from a query (e.g. a single MS2 spectrum from a MGF file) to a given peptide. A query may match more than one
    # peptide at a given score, and Mascot will report these in order of descending significance, or "rank".
    #
    # From the Mascot documentation, the following represents a reasonably complete PSM entry
    #     q1_p1_db=01  # two digit integer of the search DB index, zero filled and retarded.
    #     q1_p1=missed cleavages, (-1 indicates no match)
    #           peptide Mr,
    #           delta,
    #           number of ions matched,
    #           peptide string,
    #           peaks used from Ions1,
    #           variable modifications string,
    #           ions score,
    #           ion series found,
    #           peaks used from Ions2,
    #           peaks used from Ions3;
    #           "accession string":frame number:start:end:multiplicity, # data for first protein
    #           "accession string":frame number:start:end:multiplicity, # data for second protein, etc.
    #     q1_p1_et_mods=modification mass,
    #                   neutral loss mass,
    #                   modification description
    #     q1_p1_primary_nl=neutral loss string
    #     q1_p1_drange=startPos:endPos
    #     q1_p1_terms=residue,residue:residue,residue # flanking AA for each protien, in order
    #
    class PSM

      attr_accessor :query
      attr_accessor :rank
      attr_accessor :missed_cleavages
      attr_accessor :mr
      attr_accessor :delta
      attr_accessor :num_ions_matched
      attr_accessor :pep
      attr_accessor :ions1
      attr_accessor :var_mods_str
      attr_accessor :score
      attr_accessor :ion_series_str
      attr_accessor :ions2
      attr_accessor :ions3
      attr_accessor :proteins
      attr_accessor :dbs
      attr_accessor :terms
      attr_accessor :attrs

      # @param psm_entry [Array] The multi-line string entry from the Mascot DAT file
      # @return [Mascot::DAT::PSM]
      def initialize(psm_entry)
        parse_entry(psm_entry)
      end

      private
      # Parses the query entry multi-line string from the Mascot DAT file
      # @private
      # @param psm_entry [Array]
      # @return [Mascot::DAT::PSM]
      def parse_entry psm_entry
        psm_entry.each do |l|
          k,v = l.split "="
          case k
          when /^q(\d+)_p(\d+)$/
            @query = $1.to_i
            @rank = $2.to_i
            psm_vals, prots  = v.split(";")
            psm_vals = psm_vals.split(',')
            @missed_cleavages= psm_vals[0].to_i
            @mr              = psm_vals[1].to_f
            @delta           = psm_vals[2].to_f
            @num_ions_matched = psm_vals[3].to_i
            @pep             = psm_vals[4]
            @ions1           = psm_vals[5].to_i
            @var_mods_str    = psm_vals[6]
            @score           = psm_vals[7].to_f
            @ion_series_str  = psm_vals[8]
            @ions2           = psm_vals[9].to_i
            @ions3           = psm_vals[10].to_i

            # assign protein  s
            @proteins = prots.split(",").map do |pe|
              acc,*other_vals =  pe.split(":")
              acc.gsub!(/\"/,'')
              [acc] + other_vals.map {|e| e.to_i }
            end
          when /db$/
            # split on 2 chars, call to_i
            @dbs = v.split(/(\d{2})/).grep(/^\d+$/).collect { |e| e.to_i }
          when /terms$/
            # for each protein, I have to add the term AA
            @terms = v.split(":").collect {|t| t.split(",") }
          end
        end
      end
    end
  end
end