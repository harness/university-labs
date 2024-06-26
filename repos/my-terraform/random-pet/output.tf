output pet-name {
  value = random_pet.my-pet.id
  sensitive = false
  description = "Print the name of the pet"
}