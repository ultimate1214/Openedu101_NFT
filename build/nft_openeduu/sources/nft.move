module openedu::nft{
       friend openedu::nftbox;
       
       use sui::object;
       use std::string;
       use sui::url;
       use sui::tx_context;
       use sui::transfer;
       
       struct EDUNFT has key, store{
       	      id: object::UID,
	      name: string::String,
	      link: url::Url, //https://openedu101.com/nft/{id}
	      image_url :url::Url, //https://openedu101.com/{id}.png -> ipfs://{image_url}
	      description: string::String,
	      creator: string::String	      
       }

       public(friend) fun mint(_name: vector<u8>, _link: vector<u8>, _image_url: vector<u8>, _description: vector<u8>, _creator: vector<u8>, ctx: &mut tx_context::TxContext): EDUNFT{
       	   EDUNFT{
	       id: object::new(ctx),
	       name: string::utf8(_name),
	       link: url::new_unsafe_from_bytes(_link),
	       image_url: url::new_unsafe_from_bytes(_image_url),
	       description: string::utf8(_description),
	       creator: string::utf8(_creator)
	   }
	   //transfer::transfer(nft, tx_context::sender(ctx))
       }

       public fun update_name(nft: &mut EDUNFT, _name: vector<u8>){
       	   nft.name = string::utf8(_name);
       }

       public fun get_name(nft: &EDUNFT): &string::String{
       	      &nft.name
       }

       #[test_only]
       public fun mint_for_test(
       	      name: vector<u8>,
	      link: vector<u8>,
	      image_url: vector<u8>,
	      description: vector<u8>,
	      creator: vector<u8>,
	      ctx: &mut tx_context::TxContext
	): EDUNFT{
		mint(name, link, image_url, description, creator, ctx)
	}
}

#[test_only]
module openedu::nft_for_test{
       use openedu::nft::{Self, EDUNFT};
       use sui::test_scenario as ts;
       use sui::transfer;
       use std::string;
       
       #[test]
       fun mint_test(){
       	   let addr1 = @0xA;
	   let addr2 = @0xB;

	   let scenario = ts::begin(addr1);
	   {
		let nft = nft::mint_for_test(
		    b"name",
		    b"link",
		    b"image",
		    b"description",
		    b"creator",
		    ts::ctx(&mut scenario)
		);
		transfer::public_transfer(nft, addr1);
	   };
	   ts::next_tx(&mut scenario, addr1);
	   {
		let nft = ts::take_from_sender<EDUNFT>(&mut scenario);
		transfer::public_transfer(nft, addr2);
	   };
	   ts::next_tx(&mut scenario, addr2);
	   {
		let nft = ts::take_from_sender<EDUNFT>(&mut scenario);
		nft::update_name(&mut nft, b"new name");
		assert!(*string::bytes(nft::get_name(&nft)) == b"new name", 0);
		ts::return_to_sender(&mut scenario, nft);
	   };
	   
	   ts::end(scenario);
       }

}