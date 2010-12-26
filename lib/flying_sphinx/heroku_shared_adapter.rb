class FlyingSphinx::HerokuSharedAdapter < ThinkingSphinx::PostgreSQLAdapter
  def setup
    create_array_accum_function
  end
end
