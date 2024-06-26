'use client'
import { React, useState } from "react";
import { Button } from "@/components/ui/button"
import {
    Dialog,
    DialogContent,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
  } from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import UserList from "./UserList";
import { PlusCircledIcon } from "@radix-ui/react-icons"

const AddUser = () => {

  const USER_API_URL = `${process.env.UMS_URL}`;
  const USER_API_URL_CREATE = USER_API_URL + "/api/v1/create";
  const [open, setOpen] = useState(false);
  const [user, setUser] = useState({
    name: "",
    email: "",
    phone: "",
  });

  const [responseUser, setResponseUser] = useState({
    name: "",
    email: "",
    phone: "",
  });

  const handleChange = (event) => {
    const value = event.target.value;
    setUser({ ...user, [event.target.name]: value });
  };

  const saveUser = async (e) => {
    e.preventDefault();
    const response = await fetch(USER_API_URL_CREATE, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(user),
    });
    if (!response.ok) {
      throw new Error("Something went wrong");
    }
    const _user = await response.json();
    setResponseUser(_user);
    reset(e);
  };

  const reset = (e) => {
    e.preventDefault();
    setUser({
      name: "",
      email: "",
      phone: "",
    });
    setOpen(false);
  };

  return (
    <div className="container mx-auto my-8">
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <div className="text-right">
        <Button className="bg-green-500 hover:bg-green-600 hover:cursor-pointer mx-3">
        <PlusCircledIcon className="mr-2 h-4 w-4" />
        Add User
        </Button>
        </div>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Add User</DialogTitle>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="name" className="text-right">
              Name
            </Label>
            <Input id="name" name="name" placeholder="John Doe" value={user.name} onChange={(e) => handleChange(e)} className="col-span-3" />
          </div>
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="email" className="text-right">
              Email
            </Label>
            <Input id="email" name="email" placeholder="yHqFP@example.com" value={user.email} onChange={(e) => handleChange(e)} className="col-span-3" />
          </div>
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="phone" className="text-right">
              Phone
            </Label>
            <Input id="phone" name="phone" placeholder="(123)-456-7890" value={user.phone} onChange={(e) => handleChange(e)} className="col-span-3" />
          </div>
        </div>
        <DialogFooter>
            <Button className="bg-green-500 hover:bg-green-600" onClick={saveUser}>Save changes</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
    <UserList user={responseUser} />
    </div>
  )
}

export default AddUser