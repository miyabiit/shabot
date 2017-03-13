module Enums
  module TaxTypeEnum
    extend Enumerize

    enumerize :tax_type, in: %w(ex in)
  end
end
