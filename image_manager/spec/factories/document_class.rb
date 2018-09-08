
FactoryBot.define do
  factory :con_cls, class: DocumentClass do
    code "consult"
    description "Consults"
  end

  factory :trn_cls, class: DocumentClass do
    code "trans"
    description "Transcription"
  end

  factory :lab_cls, class: DocumentClass do
    code "clinical_lab"
    description "Clinical Labs"
    end

  factory :face, class: DocumentClass do
    code "face_sheet"
    description "FaceSheets"
  end


end
