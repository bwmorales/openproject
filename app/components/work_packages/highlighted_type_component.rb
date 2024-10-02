# frozen_string_literal: true

class WorkPackages::HighlightedTypeComponent < ApplicationComponent
  include OpPrimer::ComponentHelpers

  def initialize(work_package:)
    super

    @type = work_package.type
  end

  def call
    render(Primer::Beta::Text.new(classes: "__hl_inline_type_#{@type.id}")) { @type.name.upcase }
  end
end
