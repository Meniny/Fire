//
//  FireResponse.swift
//  Fire
//
//  Created by Meniny on 2016-04-19.
//  Copyright © 2016 Meniny. All rights reserved.
//

import Foundation
import Jsonify

public typealias FireJSON = Jsonify

public typealias FireUserAgent = Fire.UserAgent
public typealias FireBasicAuth = Fire.BasicAuth
public typealias FireHeaderFields = Fire.HeaderFields
public typealias FireParams = Fire.Params
public typealias FireFileDescriptor = Fire.FileDescriptor

public typealias FireGenericResponseCallback = Fire.GenericResponseCallback
public typealias FireJOSNResponseCallback = Fire.JOSNResponseCallback
public typealias FireDataResponseCallback = Fire.DataResponseCallback
public typealias FireURLResponseCallback = Fire.URLResponseCallback
public typealias FireStringResponseCallback = Fire.StringResponseCallback
public typealias FireVoidCallback = Fire.VoidCallback
public typealias FireErrorCallback = Fire.ErrorCallback
public typealias FireProgressCallback = Fire.ProgressCallback

public let FireDefaultTimeout: Double = 60.0
public let FireEmptyErrorCallback: FireErrorCallback = { (error) in }

public protocol FireResponseProtocol {}

extension Jsonify: FireResponseProtocol {}
extension String: FireResponseProtocol {}
extension Data: FireResponseProtocol {}

public extension Fire {
    
    public typealias Params = [String: Any]
    public typealias UserAgent = String
    public typealias BasicAuth = (name: String, pwd: String)
    public typealias HeaderFields = [String: String]
    public typealias GenericResponseCallback = ((_ value: FireResponseProtocol?, _ response: HTTPURLResponse?, _ type: Fire.ResponseType) -> Void)
    public typealias JOSNResponseCallback = ((_ json: Jsonify, _ response: HTTPURLResponse?) -> Void)
    public typealias DataResponseCallback = ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)
    public typealias URLResponseCallback = ((_ url: URL?, _ response: HTTPURLResponse?) -> Void)
    public typealias StringResponseCallback = ((_ string: String?, _ response: HTTPURLResponse?) -> Void)
    public typealias VoidCallback = (() -> Void)
    public typealias ErrorCallback = ((_ error: Error) -> Void)
    public typealias ProgressCallback = ((_ completedBytes: Int64, _ totalBytes: Int64, _ progress: Float) -> Void)
    
    public static let DefaultTimeout: Double = 60.0
    public static let EmptyErrorCallback: FireErrorCallback = { (error) in }
    
    public enum Keys: String {
        case contentLength        = "Content-Length"
        case contentType          = "Content-Type"
        case authorization        = "Authorization"
        case contentTypeData      = "x-www-form-urlencoded"
        case contentTypeJSON      = "application/json"
        case contentTypeMultipart = "multipart/form-data"
    }
    
    /// To make a Fire request Synchronously or Asynchronously
    public typealias Dispatch = Fire.DispatchPolicy
    public enum DispatchPolicy: String {
        case synchronously = "Synchronously"
        case asynchronously = "Asynchronously"
    }
    
    public enum ResponseType {
        case JSON
        case string
        case data
    }
    
    /// HTTP method enum for Fire
    public enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DETELE"
        case HEAD = "HEAD"
        case OPTIONS = "OPTIONS"
        case PATCH = "PATCH"
    }
    
    /// Response Status Codes
    public enum ResponseStatus: Int {
        /**
         * 0
         */
        case noNetwork = 0
        
        
        /**
         * 100
         */
        case `continue` = 100
        
        /**
         * 101
         */
        case switchingProtocols = 101
        
        
        /**
         * 102
         */
        case processing = 102 //WebDAV（RFC 2518）
        
        
        /**
         * 200
         */
        case success = 200
        
        /**
         * 201
         */
        case created = 201
        
        /**
         * 202
         */
        case accepted = 202
        
        /**
         * 203
         */
        case nonAuthoritativeInformation = 203
        
        /**
         * 204
         */
        case noContent = 204
        
        
        /**
         * 205
         */
        case resetContent = 205
        
        /**
         * 206
         */
        case partialContent = 206
        
        /**
         * 207
         */
        case multiStatus = 207//WebDAV（RFC 2518）
        
        /**
         * 300
         */
        case requestError = 300// 300 Multiple Choices
        
        /**
         *
         */
        //    case UnknownError = 301
        
        /**
         * 301
         */
        case movedPermanently = 301
        
        /**
         * 302
         */
        case moveTemporarily = 302
        
        /**
         * 303
         */
        case seeOther = 303
        
        /**
         * 304
         */
        case notModified = 304
        
        /**
         * 305
         */
        case useProxy = 305
        
        /**
         * 306
         */
        case switchProxy = 306
        
        /**
         * 307
         */
        case temporaryRedirect = 307
        
        /**
         * 400
         */
        case badRequest = 400
        
        /**
         * 401
         */
        case unauthorized = 401
        
        /**
         * 402
         */
        case paymentRequired = 402
        
        /**
         * 403
         */
        case forbidden = 403//case Refused
        
        /**
         * 404
         */
        case notFound = 404
        
        /**
         * 405
         */
        case methodNotAllowed = 405
        
        /**
         * 406
         */
        case notAcceptable = 406
        
        /**
         * 407
         */
        case proxyAuthenticationRequired = 407
        
        /**
         * 408
         */
        case requestTimeout = 408
        
        /**
         * 409
         */
        case conflict = 409
        
        /**
         * 410
         */
        case gone = 410
        
        /**
         * 411
         */
        case lengthRequired = 411
        
        /**
         * 412
         */
        case preconditionFailed = 412
        
        /**
         * 413
         */
        case requestEntityTooLarge = 413
        
        /**
         * 414
         */
        case requestURITooLong = 414
        
        /**
         * 415
         */
        case unsupportedMediaType = 415
        
        /**
         * 416
         */
        case requestedRangeNotSatisfiable = 416
        
        /**
         * 417
         */
        case expectationFailed = 417
        
        /**
         * 421
         */
        case tooManyConnections = 421
        
        /**
         * 422
         */
        case unprocessableEntity = 422
        
        /**
         * 423
         */
        case locked = 423
        
        /**
         * 424
         */
        case failedDependency = 424
        
        /**
         * 425
         */
        case unorderedCollection = 425
        
        /**
         * 426
         */
        case upgradeRequired = 426
        
        /**
         * 449
         */
        case retryWith = 449// Microsoft
        
        
        /**
         * 500
         */
        case internalServerError = 500
        
        /**
         * 501
         */
        case notImplemented = 501
        
        /**
         * 502
         */
        case badGateway = 502
        
        /**
         * 503
         */
        case serviceUnavailable = 503
        
        /**
         * 504
         */
        case gatewayTimeout = 504
        
        /**
         * 505
         */
        case httpVersionNotSupported = 505
        
        /**
         * 506
         */
        case variantAlsoNegotiates = 506//RFC 2295
        
        /**
         * 507
         */
        case insufficientStorage = 507
        
        /**
         * 509
         */
        case bandwidthLimitExceeded = 509
        
        /**
         * 510
         */
        case notExtended = 510
        
        
        /**
         * 600
         */
        case unparseableResponseHeaders = 600
    }
}










// ...
