require 'test_mascot-dat-helper'
require 'mascot/dat/peptides'
require 'mascot/dat/psm'

class TestMascotDatPeptides < TestMascotDatHelper

  def setup
    super
    @peptides = @dat.peptides
  end

  def test_peptides
    assert_kind_of(Mascot::DAT::Peptides, @peptides)
  end

  def test_peptides_psmindex_not_empty
    refute_empty(@peptides.psmidx)
  end
  def test_peptides_psmindex_is_empty
    peptides = @dat.peptides(false)
    assert_empty(peptides.psmidx)
  end

  def test_peptides_first_psm_position
    # position for q1_p1 PSM from test/fixtures/example.dat
    expected_position = 1843073
    assert_equal(expected_position, @peptides.psmidx[1][1])
  end

  def test_peptides_psm_q11_p2_position
    # position for q1_p1 PSM from test/fixtures/example.dat
    expected_position =1871224
    assert_equal(expected_position, @peptides.psmidx[11][2])
  end

  def test_peptides_parse_first_psm
    # q1_p1_db=02
    # q1_p1=1,620.211197,0.220357,4,MGDAPD,24,01000000,\
    #       16.72,0002000000000000000,0,0;"IPI00848002":0:2:7:1
    # q1_p1_terms=M,Y
    # q1_p1_primary_nl=01000000
    expected_psm = ::Mascot::DAT::PSM.new()

    expected_psm.query = 1
    expected_psm.rank = 1
    expected_psm.missed_cleavages = 1
    expected_psm.mr = 620.211197
    expected_psm.delta = 0.220357
    expected_psm.num_ions_matched = 4
    expected_psm.pep = "MGDAPD"
    expected_psm.ions1 = 24
    expected_psm.var_mods_str = "01000000"
    expected_psm.score = 16.72
    expected_psm.ion_series_str = "0002000000000000000"
    expected_psm.ions2 = 0
    expected_psm.ions3 = 0
    expected_psm.proteins = [["IPI00848002",0,2,7,1]]
    expected_psm.dbs = [2]
    expected_psm.terms = [["M","Y"]]
    expected_psm.attrs = {:primary_nl => "01000000"}

    test_psm  = @peptides.psm(1,1)
    assert_equal(expected_psm, test_psm)
  end

end
