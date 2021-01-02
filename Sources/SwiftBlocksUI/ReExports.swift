//
//  ReExports.swift
//  SwiftBlocksUI
//
//  Created by Helge Heß.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct SlackBlocksModel.MessageResponse
import struct SlackBlocksModel.Token
import struct SlackBlocksModel.MessageID
import struct SlackBlocksModel.CallbackID
import struct SlackBlocksModel.TriggerID
import struct SlackBlocksModel.UserID
import struct SlackBlocksModel.ConversationID
import struct SlackBlocksModel.TeamID
import struct SlackBlocksModel.UserGroupID
import struct SlackBlocksModel.ExternalViewID

public typealias MessageResponse = SlackBlocksModel.MessageResponse
public typealias Token           = SlackBlocksModel.Token
public typealias MessageID       = SlackBlocksModel.MessageID
public typealias CallbackID      = SlackBlocksModel.CallbackID
public typealias TriggerID       = SlackBlocksModel.TriggerID
public typealias UserID          = SlackBlocksModel.UserID
public typealias ConversationID  = SlackBlocksModel.ConversationID
public typealias TeamID          = SlackBlocksModel.TeamID
public typealias UserGroupID     = SlackBlocksModel.UserGroupID
public typealias ExternalViewID  = SlackBlocksModel.ExternalViewID

@_exported import func   BlocksExpress.sslCheck
@_exported import func   BlocksExpress.verifyToken

@_exported import SlackClient
@_exported import Blocks
@_exported import struct Blocks.Group

import struct    Logging.Logger
public typealias Logger  = Logging.Logger


@_exported import let      Macro.console
@_exported import func     connect.logger
@_exported import enum     express.bodyParser
@_exported import enum     dotenv.dotenv

import MacroApp
public typealias Endpoints = MacroApp.Endpoints
public typealias App       = MacroApp.App
public typealias Use       = MacroApp.Use
public typealias Route     = MacroApp.Route
@_exported import struct   MacroApp.Group
@_exported import struct   MacroApp.Route
@_exported import func     MacroApp.Get
@_exported import func     MacroApp.Post
