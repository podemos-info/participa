require 'test_helper'

class VoteTest < ActiveSupport::TestCase

  test "should validate presence on vote" do 
    v = Vote.new
    v1 = Vote.new(user_id: 1, election_id: 1)
    v.valid?
    assert(v.errors[:user_id].include? "no puede estar en blanco")
    assert(v.errors[:election_id].include? "no puede estar en blanco")
    assert v1.valid?
  end

  test "should validate uniqueness on vote" do 
    v1 = Vote.new(user_id: 1, election_id: 1)
    v2 = Vote.new(user_id: 1, election_id: 1)
    v3 = Vote.new(user_id: 1, election_id: 2)
    v1.valid?
    v2.valid?
    assert(v2.errors.messages[:user_id].include? "ya está en uso")
    assert(v2.errors.messages[:voter_id].include? "ya está en uso")
    assert v3.valid?
  end

  test "should validate voter_id uniqueness on vote" do 
    v1 = Vote.create(user_id: 1, election_id: 1)
    v2 = Vote.create(user_id: 1, election_id: 2)
    v3 = Vote.create(user_id: 2, election_id: 1)
    assert_not_equal(v1.voter_id, v2.voter_id)
    assert_not_equal(v1.voter_id, v3.voter_id)
    assert_not_equal(v2.voter_id, v3.voter_id)
  end

  test "should generate and save voter_id on creation" do 
    v = Vote.create(user_id: 1, election_id: 1)
    assert v.voter_id?
  end

  test "should .generate_voter_id work" do 
    v = Vote.create(user_id: 1, election_id: 1)
    voter_id = v.generate_voter_id  
    assert_equal(voter_id.length, 64)
  end

  test "sould .generate_message work" do 
    e = FactoryGirl.create(:election)
    v = Vote.create(user_id: 1, election_id: e.id)
    message = v.generate_message
    assert_equal(message.split(':')[0], v.voter_id)
    assert_equal(message.split(':')[1], v.election_id.to_s)
    # es un timestamp que no podemos comprobar mas que sea epoch valido
    timestamp = message.split(':')[2]
    assert_equal(timestamp.to_i.to_s, timestamp)
  end

  test "should .generate_hash work" do
    v = Vote.create(user_id: 1, election_id: 1)
    assert_equal(v.generate_hash("test").length, 64)
  end

  test "should .url work" do
    e = FactoryGirl.create(:election)
    v = Vote.create(user_id: 1, election_id: e.id)
    assert(v.url.starts_with? "http://")
    assert(v.url.length > 64)
  end

end
