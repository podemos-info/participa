require 'test_helper'

class ElectionTest < ActiveSupport::TestCase

  test "should validate presence on election" do 
    e = Election.new
    e1 = Election.new(title: "hola mundo", agora_election_id: 1, starts_at: DateTime.now, ends_at: DateTime.now + 2.weeks)
    e.valid?
    assert(e.errors[:title].include? "no puede estar en blanco")
    assert(e.errors[:agora_election_id].include? "no puede estar en blanco")
    assert(e.errors[:starts_at].include? "no puede estar en blanco")
    assert(e.errors[:ends_at].include? "no puede estar en blanco")
    assert e1.valid?
  end

  test "should scope :actived work" do 
    e1 = Election.create(title: "hola mundo", agora_election_id: 1, starts_at: DateTime.civil(1999, 2, 2, 12, 12), ends_at: DateTime.civil(2001, 2, 2, 12, 12))
    assert e1.valid?
    assert_equal(Election.actived.count, 0)
    e2 = Election.create(title: "hola mundo", agora_election_id: 1, starts_at: DateTime.civil, ends_at: DateTime.now + 2.weeks)
    assert e2.valid?
    assert_equal(Election.actived.count, 1)
  end

end
