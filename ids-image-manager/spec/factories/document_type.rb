require './models/document_type'

FactoryBot.define do

  factory :con_1, class: DocumentType do
    code "con_1"
    description "Consult_1"
	  remote_id 2


  end

  factory :trn_1, class: DocumentType do
    code "trans_1"
    description "Transcription_1"
    remote_id 3
  end

end
