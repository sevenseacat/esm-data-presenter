# Desired interface

* `stream = Tes.EsmFile.stream("./data/Morrowind.esm")` # spits out a list of structs of different types, representing objects read
  * Then filters can be tacked on, eg. `stream |> Tes.Filter.books`
