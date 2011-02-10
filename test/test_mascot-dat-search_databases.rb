require 'test_mascot-dat-helper'
require 'mascot/dat/parameters'
require 'mascot/dat/search_databases'

class TestMascotDatSearchDatabases < TestMascotDatHelper

  def setup
    super
    @dbs = @dat.search_databases
  end

  def test_search_databases
    assert_kind_of(Mascot::DAT::SearchDatabases, @dbs)
  end

  def test_db0
    # DB=cRAP
    assert_equal("cRAP", @dbs[0])
  end
  def test_db1
    # DB2=IPI_human
    assert_equal("IPI_human", @dbs[1])
  end
end