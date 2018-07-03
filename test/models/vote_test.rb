require 'test_helper'

class VoteTest < ActiveSupport::TestCase

  test "should validate presence on vote" do
    v = Vote.new
    v.valid?
    assert(v.errors[:user_id].include? "no puede estar en blanco")
    assert(v.errors[:election_id].include? "no puede estar en blanco")
    assert(v.errors[:voter_id].include? "no puede estar en blanco")
    assert(v.errors[:voter_id].include? "No se pudo generar")
    v1 = FactoryBot.build(:vote)
    assert v1.valid?
  end

  test "should validate uniqueness on vote" do
    e1 = FactoryBot.create(:election)
    e2 = FactoryBot.create(:election)
    u = FactoryBot.create(:user)
    v1 = Vote.create(user_id: u.id, election_id: e1.id)
    v2 = Vote.create(user_id: u.id, election_id: e1.id)
    v3 = Vote.create(user_id: u.id, election_id: e2.id)
    assert v1.valid?
    assert_not v2.valid?
    assert(v2.errors.messages[:voter_id].include? "ya está en uso")
    assert v3.valid?
  end

  test "should validate voter_id uniqueness on vote" do
    e1 = FactoryBot.create(:election)
    e2 = FactoryBot.create(:election)
    u1 = FactoryBot.create(:user)
    u2 = FactoryBot.create(:user)
    v1 = Vote.create(user_id: u1.id, election_id: e1.id)
    v2 = Vote.create(user_id: u1.id, election_id: e2.id)
    v3 = Vote.create(user_id: u2.id, election_id: e1.id)
    assert_not_equal(v1.voter_id, v2.voter_id)
    assert_not_equal(v1.voter_id, v3.voter_id)
    assert_not_equal(v2.voter_id, v3.voter_id)
  end

  test "should generate and save voter_id on creation" do
    v = FactoryBot.create(:vote)
    assert v.voter_id?
  end

  test "should .generate_voter_id work" do
    v = FactoryBot.create(:vote)
    voter_id = v.generate_voter_id
    assert_equal(voter_id.length, 64)
  end

  test "sould .generate_message work" do
    v = FactoryBot.create(:vote)
    message = v.generate_message
    assert_equal(message.split(':')[0], v.voter_id)
    assert_equal(message.split(':')[2], v.scoped_agora_election_id.to_s)
    # es un timestamp que no podemos comprobar mas que sea epoch valido de hoy
    timestamp = message.split(':')[4].to_i
    assert(Time.at(timestamp).to_date == Date.today)
  end

  test "should .generate_hash work" do
    v = FactoryBot.create(:vote)
    assert_equal(v.generate_hash("test").length, 64)
  end

  test "should .url work" do
    v = FactoryBot.create(:vote)
    assert(v.url.starts_with? "https://")
    assert(v.url.length > 64)
  end

  test "should .test_url work" do
    WebMock.allow_net_connect!
    v = FactoryBot.create(:vote)
    assert(v.test_url.starts_with? "https://")
    assert(v.test_url.length > 64)
    #result = Net::HTTP.get(URI.parse(v.test_url))
    # FIXME: should point to agoravoting demo server and check the auth 
    # assert(result.include? "IE10 viewport hack for Surface/desktop Windows 8 bug")
    # WebMock.disable_net_connect!(allow_localhost: true)
    # no podemos comprobar más ya que en agoravoting no permiten ejecutarlo sin JS
  end

end
