module ImpulsaHelper

  def filetypes_to_file_filter filetype
    (ImpulsaProject::FILETYPES[filetype.to_sym].map { |ext| ".#{ext}" } + 
      ImpulsaProject::FILETYPES[filetype.to_sym].map { |ext| ImpulsaProject::EXTENSIONS[ext] } 
    ).join(",") if filetype
  end
end