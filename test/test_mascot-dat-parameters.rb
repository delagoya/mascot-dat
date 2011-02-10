require 'test_mascot-dat-helper'
require 'mascot/dat/parameters'
class TestMascotDatParameters < TestMascotDatHelper

  def setup
    super
    @parameters =  @dat.parameters
  end

  def test_params
    assert_kind_of(Mascot::DAT::Parameters, @parameters)
  end

  def test_params_mods
    assert_equal("Carbamidomethyl (C)", @parameters.parameters["MODS"])
  end

end

__END__

This is an example of the parameters section of a Mascot DAT file

--gc0p4Jq0M2Yt08jU534c0p
Content-Type: application/x-Mascot; name="parameters"

LICENSE=Licensed to: University of Pennsylvania, ITM, Philadelphia (2038128), (4 processors).
MP=
NM=
COM=test search
IATOL=
IA2TOL=
IASTOL=
IBTOL=
IB2TOL=
IBSTOL=
IYTOL=
IY2TOL=
IYSTOL=
SEG=
SEGT=
SEGTU=
LTOL=
TOL=1.2
TOLU=Da
ITH=
ITOL=0.6
ITOLU=Da
PFA=1
DB=cRAP
DB2=IPI_human
MODS=Carbamidomethyl (C)
MASS=Monoisotopic
CLE=V8-DE/Trypsin
FILE=example.mgf
PEAK=AUTO
QUE=
TWO=
SEARCH=MIS
USERNAME=angel
USEREMAIL=delagoya@gmail.com
CHARGE=2+ and 3+
INTERMEDIATE=
REPORT=AUTO
OVERVIEW=
FORMAT=Mascot generic
FORMVER=1.01
FRAG=
IT_MODS=Oxidation (M)
USER00=
USER01=
USER02=
USER03=
USER04=
USER05=
USER06=
USER07=
USER08=
USER09=
USER10=
USER11=
USER12=
PRECURSOR=
TAXONOMY=All entries
ACCESSION=
REPTYPE=peptide
SUBCLUSTER=
ICAT=
INSTRUMENT=ESI-TRAP
ERRORTOLERANT=
FRAMES=
CUTOUT=
USERID=0
QUANTITATION=Label-free [MD]
DECOY=1
PEP_ISOTOPE_ERROR=0
RULES=1,2,8,9,10,13,14,15
INTERNALS=0.0,700.0

