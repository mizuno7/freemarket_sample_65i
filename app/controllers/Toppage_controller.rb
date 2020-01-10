class ToppageController < ApplicationController
# before_action :get_category_children, :get_category_grandchildren,:get_size,
# :get_brand,:get_searchsize,:set_parent_category,
# :set_grandchild_category, :set_sizes
  def index
    @categories = Category.roots
    @products = @categories.map{|root| Product.where(category_id: root.subtree)}
    @sorted_products = @products.sort {|a,b| b.length <=> a.length }
    @popular = []
    @sorted_products.each.with_index(1) do |products, i|
      if (i <= 4)
        @popular << products
      else
        break
      end
    end

  end

  def new
    @product = Product.new
    @product.images.build
    gon.count = 0
  end

  def edit
    @product = Product.find(params[:id])
    gon.count = @product.images.length
    if @product.buyer_id != nil || @product.seller_id != current_user.id
      redirect_to root_path
    end
    @profit = (@product.price * 0.9).round
    @fee = @product.price - @profit
  end

  def show
    @product = Product.find(params[:id])
    @seller = @product.seller
    @images = @product.images.order("id DESC")
    @category = @product.category
    @child = @category.parent
    @parent = @category.root
    @brand = @product.brand
  end

  def create
    @product = Product.new(product_params)
    if (params[:images] != nil)
      if @product.save
        params[:images]['url'].each do |image|
        @product.images.create(url: image, product_id: @product.id)
        end
        redirect_to root_path
      else
        redirect_to new_product_path
      end
    else
      redirect_to new_product_path
    end
  end

  private
  
  def get_category_children
    @category_children = Category.find_by(id: "#{params[:parent_id]}", ancestry: nil).children
  end

  def get_category_grandchildren
    @category_grandchildren = Category.find("#{params[:child_id]}").children
  end

  def get_size
    @sizes = Category.find("#{params[:grandchild_id]}").sizes

  end

  def get_brand
    @brands = Brand.where('name LIKE(?)', "%#{params[:keyword]}%")
  end

  def get_searchsize
    @searchsizes = Searchsize.find("#{params[:searchsize_id]}").sizes
  end


  def set_parent_category
    @category_parent_array = [{name:'---', id:'---'}]
    Category.roots.each do |parent|
      @parent = {name: parent.name, id: parent.id}
      @category_parent_array << @parent
    end
  end

  
end