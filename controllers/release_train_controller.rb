class ReleaseTrainController < ApplicationController
  get "/display" do
    @title = "Release Train"
    haml :release_train
  end

end