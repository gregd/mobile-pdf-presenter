package com.grw.mobi.models;

import com.grw.mobi.aorm.UserGen;

public class User extends UserGen {

    public User() {}

    public String fullName() {
        return last_name + " " + first_name;
    }

    public String nameSurname() {
        return first_name + " " + last_name;
    }

}
