'use client'
import { React, useState, useEffect } from "react";
import User from './User';
import EditUser from "./EditUser";
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


const UserList = ({ user }) => {

  const USER_API_URL = `${process.env.UMS_URL}`;
  const USER_API_URL_FETCHALL = USER_API_URL + "/api/v1/fetch/all";
  const USER_API_URL_DELETE = USER_API_URL +"/api/v1/delete";
  const [users, setUsers] = useState(null);
  const [loading, setLoading] = useState(true);
  const [userEmail, setUserEmail] = useState(null);
  const [responseUser, setResponseUser] = useState(null);

  useEffect(() => {
    const fetchUsers = async () => {
        setLoading(true);
        try {
            const response = await fetch(USER_API_URL_FETCHALL, {
                method: "GET",
                headers: {
                    "Content-Type": "application/json",
                },
            });
            const users = await response.json();
            setUsers(users);
        } catch (error) {
          console.log(USER_API_URL + " Backend is not available");
        }
        setLoading(false);
    }
    fetchUsers();
  }, [user, responseUser]);

  const deleteUser = (e, email) => {
    e.preventDefault();
    fetch(USER_API_URL_DELETE + "?email=" + email, {
      method: "DELETE",
    }).then((res) => {
      if (users) {
        setUsers((prevElement) => {
          return prevElement.filter((user) => user.email !== email);
        });
      }
    });
  };

  const editUser = (e, email) => {
    e.preventDefault();
    setUserEmail(email);
  };

  return (
    <div>
      <div className="mx-auto my-8">
        <div className="flex shadow border-b">
          <Table>
            <TableHeader>
              <TableRow className="bg-gray-200">
                <TableHead>
                  Name
                </TableHead>
                <TableHead>
                  Email
                </TableHead>
                <TableHead>
                  Phone
                </TableHead>
                <TableHead className="text-right px-10">
                  Actions
                </TableHead>
              </TableRow>
            </TableHeader>
            
            {!loading && (
              <TableBody className=" bg-blue">
                {users?.map((user) => (
                  <User
                    user={user}
                    key={user.email}
                    deleteUser={deleteUser}
                    editUser={editUser}
                  />
                ))}
              </TableBody>
            )}
          </Table>
        </div>
      </div>
      <EditUser userEmail={userEmail} setResponseUser={setResponseUser} />
    </div>
  )
}

export default UserList