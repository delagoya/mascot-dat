# -*- coding: utf-8 -*-
module Mascot
  # A parser for the peptide spectrum match results of a Mascot DAT file.
  # As opposed to the other sections of a DAT file, you don't really want to
  # access this section as one big chunk in memory. It is often quite large and
  # needs to be accessed using Enumerable methods.
  #
  # From the Mascot documentation, results are CSV list with the following information
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
    require 'csv'
    # To create a peptides enumerable, you need to pass in the dat file handle and
    # the byte offset of the peptides section.
    def initialize(dat_file, byteoffset)
      @byteoffset = byteoffset
      @file = File.new(dat_file,'r')
      @file.pos = @byteoffset
      # create an in-memroy index of PSM byteoffsets
      @psm = Array.new(Array.new())
      q,p  = :0
      @file.grep(/q(\d+)_p(\d+)/) do |psm|
        i,j = $1.to_sym, $2.to_sym
        next if q == i && p == j
        unless @psm.has_key? i
          q = i
          @psm[q] = {}
        end
        @psm[i][j] = @file.pos - psm.length
        q,p = i,j
      end
    end
    def rewind
      @file.pos = @byteoffset
    end
    def parse_psm value
    end
    def parse_psm_terms value
    end
  end
end





