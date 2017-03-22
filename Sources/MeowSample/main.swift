import Meow
import MeowVapor
import Vapor

try! Meow.init("mongodb://localhost:27017/meow-sample")
try! Meow.database.drop()

let henk = User(email: "henk@example.com", name: "Henk", gender: .undecided)
try! henk.save()

let drop = Droplet()
Meow.integrate(drop)
drop.run()