module Job
  module_function

  def reload
    later 0 do
      load "#{APP_DIR_PATH}/job.rb" # TODO
    end
  end
end
