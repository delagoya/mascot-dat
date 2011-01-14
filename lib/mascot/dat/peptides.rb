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

    # A hash of the index positions for the peptide PSM matches.
    # Keys arr
    attr_reader :psmidx
    # To create a peptides enumerable, you need to pass in the dat file handle and
    # the byte offset of the peptides section.
    def initialize(dat_file, byteoffset, cache_psm_index=true)
      @byteoffset = byteoffset
      @file = File.new(dat_file,'r')
      @file.pos = @byteoffset
      @curr_psm = [1,1]
      @psmidx = Array.new()
      if cache_psm_index
        # create an in-memroy index of PSM byteoffsets
        q,p  = 0
        @boundary  = Regexp.new(@file.readline)
        @file.each do |line|
          break if line =~ boundary
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
      end
    end

    def rewind
      @file.pos = @byteoffset
    end

    def read_psm q,p
      @file.pos  =  @psmidx[q][p]
      tmp = []
      file.each do |l|
        break if l =~ @boundary
        break unless l =~ /q#{q}_p#{p}/
        tmp << l.chomp
      end
      return tmp
    end

    def parse_psm psm_arr
      psm_result = {}
      psm_arr.each do |l|
        k,v = l.split "="
        case k
        when /^q\d+_p\d+$/
          #main result, must split value
          psm_vals, prots  = v.split(";")
          psm_vals = psm_vals.split(',')
          # proteins in last element
          psm_result[:proteins] = prots.split(",").map do |pe|
            acc,*other_vals =  pe.split(":")
            acc.gsub!(/\"/,'')
            other_vals.map! {|e| e.to_i }
            [acc] + other_vals
          end
        when /db$/
          # split on 2 chars, call to_i
          psm_result[:dbs] = l.split(/(\d{2})/).grep(/\d/) { |e| e.to_i }
        when /terms$/
          # for each protein, I have to add the term AA
          psm_result[:terms] = v.split(":").collect {|t| t.split(",") }
        else
          # returns the smaller key
          k_sym = k.slice(/q\d+_p\d+_?(.+)/,1).to_sym
          psm_result[k_sym] = v
        end
      end
      psm_result
    end

    # Method to read in and return a result
    def result(query, rank)
      parse_psm(read_psm(query,rank))
    end
    def each

    end


  end
end
