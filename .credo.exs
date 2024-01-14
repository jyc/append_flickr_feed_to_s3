%{
  configs: [
    %{
      name: "default",
      checks: [
        {Credo.Check.Warning.IoInspect, false}
      ]
    }
  ]
}
