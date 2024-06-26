'use client'
import { React, useState, useEffect } from "react";
import { PersonIcon } from "@radix-ui/react-icons"
import { Badge } from "./ui/badge";

const Navbar = () => {

    const USER_API_URL = `${process.env.UMS_URL}`;
    const USER_API_URL_CONFIGINFO = USER_API_URL + "/api/v1/configinfo";
    const [configinfo, setConfiginfo] = useState({
        harnessBuildVersion: "?",
        hostName: "?",
        activeProfile: "?",
    });
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchConfig = async () => {
            setLoading(true);
            
            try {
                const response = await fetch(USER_API_URL_CONFIGINFO, {
                    method: "GET",
                    headers: {
                        "Content-Type": "application/json",
                    },
                });
                const configinfo = await response.json();
                setConfiginfo(configinfo);
            } catch (error) {
                console.log(USER_API_URL + " Backend is not available");
            }
            setLoading(false);
        }
        fetchConfig();
      }, []);

  return (
    <div className="bg-gradient-to-r from-sky-500 to-indigo-500">
        <div className="h-20 px-4 flex items-center">
            <p className="text-white font-bold flex-auto">
            <PersonIcon className="mr-2 h-4 w-4 inline" />
            Harness University Sample App
            </p>
            <div className="text-right">
  
                <Badge className="bg-amber-700 font-light text-xs text-center">
                    BuildVersion:[{process.env.NEXT_PUBLIC_BUILD_VERSION}] HostName:[{process.env.HOSTNAME}] AppProfile:[{process.env.NEXT_PUBLIC_ACTIVE_PROFILE}]
                </Badge> 
                <Badge className="bg-amber-300 text-slate-900 text-xs text-center w-24">
                    UI-Service
                </Badge>
                <br />

                <Badge className="bg-amber-700 font-light text-xs text-center">
                    BuildVersion:[{configinfo?.harnessBuildVersion}] HostName:[{configinfo?.hostName}] AppProfile:[{configinfo?.activeProfile}]
                </Badge>
                <Badge className="bg-amber-300 text-slate-900 text-xs text-center">
                    User-Service
                </Badge>
            </div>
        </div>
    </div>
  )
}

export default Navbar