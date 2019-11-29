class AudioCaptchaController < ApplicationController
  LETTERS = {
    "A"=>"A", "B"=>"Be", "C"=>"Ce", "D"=>"De", "E"=>"Efe", "G"=>"Ge", "H"=>"Hache", "I"=>"I", "J"=>"Jota", "K"=>"Ka", "L"=>"Ele", "M"=>"Eme", "N"=>"Ene",
    "O"=>"O", "P"=>"Pe", "Q"=>"Cu", "R"=>"Erre", "S"=>"Ese", "T"=>"Te", "U"=>"U", "V"=>"Uve", "W"=>"Uve doble", "X"=>"Equis", "Y"=>"Y griega", "Z"=>"Zeta"
  }.freeze

  def index
    FileUtils.mkdir_p file_dir

    speech.save file_path

    send_file file_path, type: 'audio/mp3', disposition: :inline
  end

  private

  def speech
    @speech ||= ESpeak::Speech.new(
      captcha_value_spelling,
      voice: "es+#{Random.rand(2) > 0 ? 'f' : 'm'}#{Random.rand(4)}",
      speed: 80 + Random.rand(40),
      pitch: Random.rand(30),
      capital: Random.rand(20)
    )
  end

  def captcha_value_spelling
    @captcha_value_spelling ||= captcha_value.chars.map {|letter| LETTERS[letter]} .join " "
  end

  def captcha_value
    @captcha_value ||= SimpleCaptcha::Utils::simple_captcha_value(captcha_key)
  end

  def captcha_key
    @captcha_key ||= params[:captcha_key]
  end

  def file_path
    @file_path ||= "#{file_dir}/#{captcha_key}.mp3"
  end

  def file_dir
    @file_dir ||= "#{Rails.root}/tmp/audios"
  end
end