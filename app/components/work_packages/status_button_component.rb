# frozen_string_literal: true

class WorkPackages::StatusButtonComponent < ApplicationComponent
  include OpPrimer::ComponentHelpers

  def initialize(work_package:)
    super

    @work_package = work_package
    @status = work_package.status
  end
end
