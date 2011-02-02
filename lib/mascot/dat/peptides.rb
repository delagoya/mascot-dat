require 'csv'
module Mascot
  # A parser for the peptide spectrum match results of a Mascot DAT file.
  # As opposed to the other sections of a DAT file, you don't really want to
  # access this section as one big chunk in memory. It is often quite large and
  # needs to be accessed using Enumerable methods.
  #
  # From the Mascot documentation, results are CSV list with the following information
  #     q1_p1_db=01  # two digit integer of the search DB index, zero filled and retarded.
  #     q1_p1=missed cleavages, (–1 indicates no match)
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
  #           “accession string”:frame number:start:end:multiplicity, # data for first protein
  #           “accession string”:frame number:start:end:multiplicity, # data for second protein, etc.
  #     q1_p1_et_mods=modification mass,
  #                   neutral loss mass,
  #                   modification description
  #     q1_p1_primary_nl=neutral loss string
  #     q1_p1_drange=startPos:endPos
  #     q1_p1_terms=residue,residue:residue,residue # flanking AA for each protien, in order
  #


  class DAT::Peptides
    include Enumerable
    # A hash of the index positions for the peptide PSM matches.
    # Keys arr
    attr_reader :psmidx, :byteoffset, :endbytepos

    # To create a peptides enumerable, you need to pass in the dat file handle and
    # the byte offset of the peptides section.
    def initialize(dat_file, byteoffset, cache_psm_index=true)
      @byteoffset = byteoffset
      @endbytepos = nil

      @file = File.new(dat_file,'r')
      @file.pos = @byteoffset
      @curr_psm = [1,1]
      @psmidx = []
      if cache_psm_index
        index_psm_positions
      end
    end

    def index_psm_positions
      # create an in-memroy index of PSM byteoffsets
      q,p  = 0
      boundary_line = @file.readline
      @boundary   = Regexp.new(boundary_line)
      @file.each do |line|
        break if line =~ @boundary
        if (line =~ /q(\d+)_p(\d+)/)
          i,j = $1.to_i, $2.to_i
          next if q == i && p == j
          unless @psmidx[i].kind_of? Array
            q = i
            @psmidx[q] = []
          end
          @psmidx[i][j] = @file.pos - line.length
          q,p = i,j
        end
      end
      @endbytepos = @file.pos - boundary_line.length
      rewind
    end


    def rewind
      @file.pos = @byteoffset
    end

    def psm q,p
      @file.pos  =  @psmidx[q][p]
      next_psm
    end

    def next_psm
      return nil if @file.pos >= @endbytepos
      # get the initial values for query & rank
      tmp = []
      tmp << @file.readline.chomp
      tmp[0] =~ /q(\d+)_p(\d+)/
      q = $1
      p = $2
      @file.each do |l|
        break if l =~ @boundary
        break unless l =~ /^q#{q}_p#{p}/
        tmp << l.chomp
      end
      parse_psm(tmp)
    end

    def parse_psm psm_arr
      psm_result = ::Mascot::DAT::PSM.new()

      psm_arr.each do |l|
        k,v = l.split "="
        case k
        when /^q\d+_p\d+$/
          #main result, must split value
          psm_vals, prots  = v.split(";")
          psm_vals = psm_vals.split(',')
          psm_result.missed_cleavages= psm_vals[0].to_i
          psm_result.mr              = psm_vals[1].to_f
          psm_result.delta           = psm_vals[2].to_f
          psm_result.num_ions_matched = psm_vals[3].to_i
          psm_result.pep             = psm_vals[4]
          psm_result.ions1           = psm_vals[5].to_i
          psm_result.var_mods_str    = psm_vals[6]
          psm_result.score           = psm_vals[7].to_f
          psm_result.ion_series_str  = psm_vals[8]
          psm_result.ions2           = psm_vals[9].to_i
          psm_result.ions3           = psm_vals[10].to_i

          # assign proteins
          psm_result.proteins = prots.split(",").map do |pe|
            acc,*other_vals =  pe.split(":")
            acc.gsub!(/\"/,'')
            [acc] + other_vals.map {|e| e.to_i }
          end
        when /db$/
          # split on 2 chars, call to_i
          psm_result.dbs = l.split(/(\d{2})/).grep(/\d+/) { |e| e.to_i }
        when /terms$/
          # for each protein, I have to add the term AA
          psm_result.terms = v.split(":").collect {|t| t.split(",") }
        else
          # returns the smaller key
          k_sym = k.slice(/q\d+_p\d+_?(.+)/,1).to_sym
          psm_result.attrs[k_sym] = v
        end
      end
      psm_result
    end

    def each
      while @file.pos < @endbytepos
        yield next_psm()
      end
    end
  end
end
