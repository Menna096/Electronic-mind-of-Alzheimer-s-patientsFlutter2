package com.actions

class Action(
    val name: String
) {

    val type by lazy { ActionType.getTypeByName(name) }

}
