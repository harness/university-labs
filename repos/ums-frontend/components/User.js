import React from 'react'
import {
    Table,
    TableBody,
    TableCaption,
    TableCell,
    TableFooter,
    TableHead,
    TableHeader,
    TableRow,
  } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Pencil2Icon, MinusCircledIcon } from "@radix-ui/react-icons"

const User = ({ user, deleteUser, editUser }) => {
    return (
      <TableRow key={user.email}>
        <TableCell>
          {user.name}
        </TableCell>
        <TableCell>
          {user.email}
        </TableCell>
        <TableCell>
          {user.phone}

        </TableCell>
        <TableCell className=" text-right">
        <Button 
            onClick={(e, id) => editUser(e, user.email)}
            className="bg-zinc-500 hover:bg-zinc-600 hover:cursor-pointer mx-2">
            <Pencil2Icon className=" h-4 w-4" />

          </Button>
          <Button
            onClick={(e, id) => deleteUser(e, user.email)}
            className="bg-red-500 hover:bg-red-600 hover:cursor-pointer">
            <MinusCircledIcon className="h-4 w-4" />

          </Button>
        </TableCell>
      </TableRow>
    );
  };

export default User