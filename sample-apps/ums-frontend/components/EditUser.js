'use client'
import { React, useState, useEffect } from "react";
import { Button } from "@/components/ui/button"
import {
    Dialog,
    DialogClose,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
  } from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

const EditUser = ({ userEmail, setResponseUser }) => {

    const USER_API_URL = `${process.env.UMS_URL}`;;
    const USER_API_URL_FETCH = USER_API_URL + "/api/v1/fetch";
    const USER_API_URL_UPDATE = USER_API_URL + "/api/v1/update";

    const [open, setOpen] = useState(false);
    const [user, setUser] = useState({
      name: "",
      email: "",
      phone: "",
    });
  
    useEffect(() => {
      const fetchData = async () => {
        try {
          const response = await fetch(USER_API_URL_FETCH + "?email=" + userEmail, {
            method: "GET",
            headers: {
              "Content-Type": "application/json",
            },
          });
          const _user = await response.json();
          setUser(_user);
          setOpen(true);
        } catch (error) {
          console.log(error);
        }
      };
      if (userEmail) {
        fetchData();
      }
    }, [userEmail]);
  
    const handleChange = (event) => {
      const value = event.target.value;
      setUser({ ...user, [event.target.name]: value });
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
  
    const updateUser = async (e) => {
      e.preventDefault();
      const response = await fetch(USER_API_URL_UPDATE, {
        method: "PUT",
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

  return (
    <div>
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Edit Phone</DialogTitle>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="phone" className="text-right">
              Phone
            </Label>
            <Input id="phone" name="phone" value={user.phone} onChange={(e) => handleChange(e)} className="col-span-3" />
          </div>
        </div>
        <DialogFooter>
            <Button onClick={updateUser}>Save changes</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
    </div>
  )
}

export default EditUser