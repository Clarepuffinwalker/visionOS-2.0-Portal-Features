//
//  ContentView.swift
//  Portal
//
//  Created by ClareZhou on 2024/9/10.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        RealityView { content in
            
            let world = makeWorld()
            let portal = makePortal(world:world)
            
            content.add(world)
            content.add(portal)
            
            }
        }
    public func makeWorld() -> Entity{
        let world = Entity()
        world.components[WorldComponent.self] = .init()
        
        //IBL Lighting
        if let environment = try? EnvironmentResource.load(named: "Light"){
            world.components[ImageBasedLightComponent.self] = .init(source: .single(environment),intensityExponent: 2.0)
            world.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: world)
        }
        
        // World Background - Image
        /*
        let resource = try! TextureResource.load(named: "pokemon03")
        var material = UnlitMaterial()
        material.color = .init(texture: .init(resource))
        let background = Entity()
        background.components.set(ModelComponent(
            mesh: .generateSphere(radius: 0.8),
                                           materials: [material]))
        background.scale.x *= -1
        world.addChild(background)
         */
        // World Background - Model
        if let pokemonCenter = try? Entity.load(named: "Pokemon_Center_Emerald") {
            pokemonCenter.scale = [0.003,0.003,0.003]
            pokemonCenter.position = [0,-0.5,-0.5]
            world.addChild(pokemonCenter)
        }
        
        //3D Objects
        if let pokemon = try? Entity.load(named: "Mew_Flying") {
            pokemon.scale = [0.005,0.005,0.005]
            pokemon.transform.rotation = simd_quatf(angle: .pi/(-6), axis: [1,0,0])
            pokemon.position = [0,-0.25,0]
            
            // Add PortalCrossingComponent
            pokemon.components[PortalCrossingComponent.self] = .init()
            
            world.addChild(pokemon)
        }

        return world
    }
    
    public func makePortal(world:Entity) -> Entity{
        let portal = Entity()
        portal.components[ModelComponent.self] = .init(mesh: .generatePlane(width:0.8, height: 0.8, cornerRadius:0.8), materials: [PortalMaterial()])
        portal.components[PortalComponent.self] = .init(target: world)
        
        
        if #available(visionOS 2.0, *) {
            let portalComponent = PortalComponent(
                target: world,
                clippingMode: .disabled,
                crossingMode: .plane(.positiveZ)
            )
            portal.components.set(portalComponent)
        } else {
            // Fallback on earlier versions
        }
        
        return portal
    }
}


#Preview(windowStyle: .volumetric) {
    ContentView()
}
