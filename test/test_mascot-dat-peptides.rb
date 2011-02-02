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
    q1p1_psm  = @peptides.psm(1,1)
    assert_equal(1, q1p1_psm.query)
    assert_equal(1, q1p1_psm.rank)
    assert_equal(1, q1p1_psm.missed_cleavages)
    assert_equal(620.211197, q1p1_psm.mr)
    assert_equal(0.220357, q1p1_psm.delta)
    assert_equal(4, q1p1_psm.num_ions_matched)
    assert_equal("MGDAPD", q1p1_psm.pep)
    assert_equal(24, q1p1_psm.ions1)
    assert_equal("01000000", q1p1_psm.var_mods_str)
    assert_equal(16.72, q1p1_psm.score)
    assert_equal("0002000000000000000", q1p1_psm.ion_series_str)
    assert_equal(0, q1p1_psm.ions2)
    assert_equal(0, q1p1_psm.ions3)
    assert_equal([["IPI00848002",0,2,7,1]], q1p1_psm.proteins)
    assert_equal([2], q1p1_psm.dbs)
    assert_equal([["M","Y"]], q1p1_psm.terms)
    assert_equal({:primary_nl => "01000000"}, q1p1_psm.attrs)
  end

end
