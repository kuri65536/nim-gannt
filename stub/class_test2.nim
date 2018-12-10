type
  Animal = ref object of RootObj
    name: string
    age: int

  Dog = ref object of Animal
    id: int

method vocalize(self: Animal): string {.base.} = "..."
method vocalize(self: Dog): string = "bow"



type
  Person = ref object of RootObj
    name*: string  # the * means that `name` is accessible from other modules
    age: int       # no * means that the field is hidden from other modules

  Student = ref object of Person # Student inherits from Person
    id: int                      # with an id field

var
  student: Student
  person: Person
assert(student of Student) # is true
# object construction:
student = Student(name: "Anton", age: 5, id: 2)
echo student[]

var i: Dog
assert(i of Dog) # is true
i = Dog(name: "abc", age: 12)
echo i.vocalize()

