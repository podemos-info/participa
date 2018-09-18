# frozen_string_literal: true

require 'rails_helper'

describe Vote do
  subject(:vote) { Vote.new(user: user, election: election) }

  let(:user) { User.new(document_vatid: document_vatid, document_type: document_type) }
  let(:election) { Election.new voter_id_template: voter_id_template }
  let(:document_type) { 1 }
  let(:document_vatid) { "1R" }
  let(:voter_id_template) { nil }

  describe 'voter_id generation' do
    describe 'normalize_identifier' do
      subject { vote.send(:normalize_identifier, identifier) }

      {
        'removes bad characters from %s' => {
          ' A ' => 'A',
          ' +566AçA7Uñ ' => '566AA7U'
        },

        'converts %s to uppercase' => {
          'aa678bBb' => 'AA678BBB',
          '56tR10Mm' => '56TR10MM'
        },

        'removes left zeros from %s' => {
          '00001' => '1',
          '019377' => '19377',
          '100100' => '100100',
          '07650A0' => '7650A',
          '0974TT00110' => '974TT110',
          '0123456A' => '123456A'
        },

        'normalizes %s' => {
          '000+*6.01' => '601',
          '+019377' => '19377',
          '1001$00' => '100100',
          '07650æ0' => '76500',
          '0974TT0011-0' => '974TT110'
        }
      }.each do |title, data|
        data.each do |input, output|
          context(title % input) do
            let(:identifier) { input }

            it { is_expected.to eq(output) }
          end
        end
      end
    end

    describe 'generate_voter_id' do
      subject { vote.generate_voter_id }

      let(:voter_id_template) { '%{normalized_vatid}:%{shared_secret}' }

      before do
        allow(election).to receive(:server_shared_key).and_return(server_shared_key)
      end

      {
        [1, '0123456A', 'elpastelestaenelhorno']  => '76641d6331c31a8ee2584fcd292c586e9cdb4ed2fb4ba053d37b2e5acd3d879d',
        [1, '0123456A', 'la contraseña']          => 'e108d7f402dc5497969a0cb2150af57586cf340ef7f09df538b523cc38be8484',
        [2, 'X38642F',  'geiJai5ohzaig6zaexa0']   => '88b3b4392d6356ad041358df3d9c73049604ce658bd662741b155bfd38a8eaa4'
      }.each do |params, output|
        context "hashing #{params[1]} with secret #{params[2]}" do
          let(:document_type) { params[0] }
          let(:document_vatid) { params[1] }
          let(:server_shared_key) { params[2] }

          it { is_expected.to eq(output) }
        end
      end
    end
  end
end
