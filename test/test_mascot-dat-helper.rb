require 'test/unit'
require 'mascot/dat'

class TestMascotDatHelper < Test::Unit::TestCase
  def setup
    @dat = Mascot::DAT.open("test/fixtures/example.dat")
  end
  def test_canary
    pass
  end

end
