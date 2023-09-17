
//this is a Cart model class

class Cart{
  final String userId;
  final String cartItem;
  final String cartItemQuantity;
  final String cartItemPrice;
  final String cartItemImage;

  Cart({
    required this.userId,
    required this.cartItem,
    required this.cartItemQuantity,
    required this.cartItemPrice,
    required this.cartItemImage,
  });

}